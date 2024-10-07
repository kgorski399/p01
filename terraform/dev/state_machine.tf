resource "aws_sfn_state_machine" "farm_state_machine" {
  name     = "FarmStateMachine"
  role_arn = aws_iam_role.sfn_role.arn

  definition = jsonencode({
    "StartAt": "UpdateSatisfaction",
    "States": {
      "UpdateSatisfaction": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.update_satisfaction_lambda.arn}",
        "Next": "SatisfactionCheck"
      },
      "IncreaseAnimalCount": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.increase_animal_lambda.arn}",
        "Next": "EndProcess"
      },
      "DecreaseAnimalCount": {
        "Type": "Task",
        "Resource": "${aws_lambda_function.decrease_animal_lambda.arn}",
        "Next": "EndProcess"
      },
      "SatisfactionCheck": {
        "Type": "Choice",
        "Choices": [
          {
            "Variable": "$.satisfaction",
            "NumericGreaterThan": 80,
            "Next": "IncreaseAnimalCount"
          },
          {
            "Variable": "$.satisfaction",
            "NumericLessThanEquals": 50,
            "Next": "DecreaseAnimalCount"
          }
        ],
        "Default": "EndProcess"
      },
      "EndProcess": {
        "Type": "Succeed"
      }
    }
  })
}


resource "aws_iam_role" "sfn_role" {
  name = "FarmStateMachineRole"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "states.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "sfn_policy" {
  name = "FarmStateMachinePolicy"
  role = aws_iam_role.sfn_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "lambda:InvokeFunction",
        "Resource": [
          "${aws_lambda_function.update_satisfaction_lambda.arn}",
          "${aws_lambda_function.increase_animal_lambda.arn}",
          "${aws_lambda_function.decrease_animal_lambda.arn}"
        ]
      }
    ]
  })
}