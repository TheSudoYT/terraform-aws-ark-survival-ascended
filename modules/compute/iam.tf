resource "aws_iam_role" "instance_role" {
  count = var.custom_gameusersettings_s3 == true ? 1 : 0

  name               = "ark-instance-role-${data.aws_region.current.name}"
  path               = "/"
  assume_role_policy = file("${path.module}/templates/ark-instance-role.json")
}

resource "aws_iam_role_policy" "instance_role_policy" {
  count = var.custom_gameusersettings_s3 == true ? 1 : 0

  name = "ark-instance-role-policy-${data.aws_region.current.name}"
  policy = templatefile(
    "${path.module}/templates/-instance-role-policy.json",
    {
      gameusersettings_s3_bucket_arn = aws_s3_bucket.ark.id
    }
  )
  role = aws_iam_role.instance_role.id
}

resource "aws_iam_instance_profile" "instance_profile" {
  count = var.custom_gameusersettings_s3 == true ? 1 : 0

  name = "ark-instance-profile-${data.aws_region.current.name}"
  path = "/"
  role = aws_iam_role.instance_role.name
}