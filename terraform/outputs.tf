output "lambda_function_url" {
  description = "Lambda Function URL - Use this in Sumo Logic webhook"
  value       = aws_lambda_function_url.restart_url.function_url
}

output "ec2_instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.app_server.id
}

output "sns_topic_arn" {
  description = "SNS Topic ARN"
  value       = aws_sns_topic.alerts.arn
}