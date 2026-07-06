#!/bin/bash
set -euo pipefail

echo "Bootstrapping web application instance [${environment}]"

# Write environment for the application
cat > /etc/profile.d/webapp.sh << EOF
export ENVIRONMENT="${environment}"
export RDS_ADDRESS="${rds_address}"
export RDS_PORT="${rds_port}"
export S3_BUCKET="${s3_bucket}"
EOF

# Mark bootstrap complete
echo "Bootstrap complete"
