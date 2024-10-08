resource "aws_sns_topic" "alarm_notifications" {
  name = "AlarmNotifications-${var.env}"
}

resource "aws_sns_topic_subscription" "sms_subscription" {
  topic_arn  = aws_sns_topic.alarm_notifications.arn
  protocol   = "sms"
  endpoint   = aws_ssm_parameter.sms_number.value
  depends_on = [aws_ssm_parameter.sms_number]

}

variable "sms_number" {
  description = "phone number for sms notifs"
  type        = string
}

resource "aws_ssm_parameter" "sms_number" {
  name        = "sms_number"
  type        = "String"
  value       = var.sms_number
  description = "Numer telefonu do powiadomień SMS"
}
