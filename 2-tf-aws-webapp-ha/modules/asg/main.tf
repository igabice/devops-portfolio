data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "instance" {
  name        = "${var.environment}-instance-sg"
  description = "Default security group for EC2 instances"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-instance-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "${var.environment}-web-"
  image_id      = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = concat(
    [aws_security_group.instance.id],
    var.app_security_group_ids,
  )

  user_data = base64encode(templatefile(
    coalesce(var.user_data_template, "${path.module}/user_data.sh.tpl"),
    {
      environment = var.environment
      rds_address = var.rds_address
      rds_port    = var.rds_port
      s3_bucket   = var.static_assets_bucket
    }
  ))

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = true
      encrypted             = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.environment}-web-instance"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }

  tags = {
    Name        = "${var.environment}-web-instance"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_autoscaling_group" "web" {
  name                      = "${var.environment}-web-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [var.target_group_arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-web-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "terraform"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.environment}-web-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.environment}-web-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.environment}-web-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.scaling_cpu_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.scaling_cpu_threshold
  alarm_description   = "Scale out when CPU exceeds ${var.scaling_cpu_threshold}%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.environment}-web-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.scaling_cpu_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.scaling_cpu_threshold
  alarm_description   = "Scale in when CPU drops below ${var.scaling_cpu_threshold}%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}
