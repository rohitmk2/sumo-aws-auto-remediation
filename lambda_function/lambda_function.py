import os
import boto3
import json
import logging

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    This function restarts an EC2 instance when triggered by Sumo Logic
    """

# Initialize AWS clients
    ec2 = boto3.client('ec2')
    sns = boto3.client('sns')

# Get configuration from environment variables
    instance_id = os.environ.get('INSTANCE_ID')
    sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')

try:
        # Log what we received
        logger.info(f"Received Sumo Logic alert: {json.dumps(event)}")
        
        # Check instance state
        logger.info(f"Checking status of instance {instance_id}")
        response = ec2.describe_instances(InstanceIds=[instance_id])
        
        instance_state = response['Reservations'][0]['Instances'][0]['State']['Name']
        logger.info(f"Instance {instance_id} is currently {instance_state}")


# Only restart if running
        if instance_state == 'running':
            logger.info(f"Restarting instance {instance_id}")
            ec2.reboot_instances(InstanceIds=[instance_id])
            message = f"✅ SUCCESS: Restarted EC2 instance {instance_id} due to high API response times detected by Sumo Logic"
        else:
            message = f"⚠️ WARNING: Instance {instance_id} is in state '{instance_state}', cannot restart"
            logger.warning(message)

# Send notification
        logger.info("Sending SNS notification")
        sns.publish(
            TopicArn=sns_topic_arn,
            Subject='EC2 Restart Alert - Sumo Logic Trigger',
            Message=message
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': message})
        }

except Exception as e:
        error_message = f"❌ ERROR: Failed to restart instance {instance_id}. Error: {str(e)}"
        logger.error(error_message)
        
        try:
            sns.publish(
                TopicArn=sns_topic_arn,
                Subject='EC2 Restart FAILED',
                Message=error_message
            )
        except:
            pass
        
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }