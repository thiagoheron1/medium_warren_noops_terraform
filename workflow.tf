locals {
  pipeline_name = "Warren-Pipeline-Example"
  cluster_key   = "Single-Cluster-Warren-Pipeline-Example"

  # Nodes
  spark_version = "10.4.x-scala2.12"
  node_type_id  = "i3.xlarge"

  # Workers
  num_workers     = 1
  first_on_demand = 1

  # Retries
  max_retries               = 3
  retry_on_timeout          = true
  min_retry_interval_millis = 600000 # 10m
  max_concurrent_runs       = 1

  # Schedules
  schedule_cron     = "0 0 23 ? * *"
  schedule_timezone = "America/Sao_Paulo"

  # GitHub
  git_url      = "https://github.com/warrenbrasil/medium_warren_noops_pipelines.git"
  git_provider = "gitHub"
  git_branch   = "main"

  # Notifcations
  on_start_email_notifications = ["seu_email@email.com.br"]
  on_failure_notifications     = ["seu_email@email.com.br"]
  on_success_notifications     = ["seu_email@email.com.br"]
}

resource "databricks_job" "warren_pipeline_example" {
  name                = local.pipeline_name
  max_concurrent_runs = local.max_concurrent_runs

  schedule {
    quartz_cron_expression = local.schedule_cron
    timezone_id            = local.schedule_timezone
  }

  git_source {
    url      = local.git_url
    provider = local.git_provider
    branch   = local.git_branch
  }

  email_notifications {
    on_start   = local.on_start_email_notifications
    on_failure = local.on_failure_notifications
    on_success = local.on_success_notifications
  }

  tags = {
    Service      = "Databricks"
    Team         = "dataops@dataplaform"
    PipelineName = local.pipeline_name
  }

  job_cluster {
    job_cluster_key = local.cluster_key

    new_cluster {
      num_workers   = local.num_workers
      spark_version = local.spark_version
      node_type_id  = local.node_type_id
      spark_conf    = {}

      aws_attributes {
        instance_profile_arn = "arn:aws:iam::<<YOUR_AWS_ACCOUNT_ID>>:instance-profile/${aws_iam_instance_profile.aws_workflow_pipeline_example.name}"
        zone_id              = "us-east-1"
        first_on_demand      = local.first_on_demand
      }
    }
  }


  # Task Name: "Task-1"
  task {
    task_key                  = "Task-1"
    max_retries               = local.max_retries
    retry_on_timeout          = local.retry_on_timeout
    min_retry_interval_millis = local.min_retry_interval_millis
    job_cluster_key           = local.cluster_key

    library {
      pypi {
        package = "pandas==1.5.1"
      }
    }

    notebook_task {
      notebook_path = "medium_warren_noops_pipelines/task_1"
      base_parameters = {
        "start_date" = "{{start_date}}"
      }
    }
  }

  # Task Name: "Task-2"
  task {
    task_key                  = "Task-2"
    max_retries               = local.max_retries
    retry_on_timeout          = local.retry_on_timeout
    min_retry_interval_millis = local.min_retry_interval_millis
    job_cluster_key           = local.cluster_key

    depends_on {
      task_key = "Task-1"
    }

    library {
      pypi {
        package = "pandas==1.5.1"
      }
    }

    notebook_task {
      notebook_path = "medium_warren_noops_pipelines/task_2"
      base_parameters = {
        "start_date" = "{{start_date}}"
      }
    }
  }




}