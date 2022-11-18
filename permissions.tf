# Criação da Role na AWS
resource "aws_iam_role" "workflow_pipeline_example" {
  name               = "Workflow-Pipeline-Example"
  assume_role_policy = file("./jsons/RoleDatabricksPipelines.json")
}

# Criação de Instance Profile na AWS conectada com a Role.
resource "aws_iam_instance_profile" "aws_workflow_pipeline_example" {
  name = "Instance-Profile-Workflow-Pipeline-Example"
  role = aws_iam_role.workflow_pipeline_example.name
}

# Criação de Instance Profile no Databricks conectado ao Instance Profiele AWS.
resource "databricks_instance_profile" "databricks_workflow_pipeline_example" {
  instance_profile_arn = aws_iam_instance_profile.aws_workflow_pipeline_example.arn
  skip_validation      = true
}


resource "aws_iam_policy" "s3_access_pipeline_example" {
  name        = "S3-Access-Pipeline-Example"
  path        = "/"
  description = "Policy com acessos aos diretorios do pipeline de exemplo no S3"
  policy      = file("./jsons/PolicyS3.json")
}

resource "aws_iam_role_policy_attachment" "s3_access_pipeline_example" {
  policy_arn = aws_iam_policy.s3_access_pipeline_example.arn
  role       = aws_iam_role.workflow_pipeline_example.name
}

