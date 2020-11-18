/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  region_map = { for r in var.regions : r => r } // for_each does not work with lists yet.
}

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

resource "google_cloud_run_service" "default" {
  for_each = local.region_map

  name     = "${var.name}--${each.value}"
  location = each.value
  project  = var.project_id

  template {
    spec {
      containers {
        image = var.image
      }
    }
  }
}

resource "google_cloud_run_service_iam_member" "default" {
  for_each = local.region_map

  location = google_cloud_run_service.default[each.key].location
  project  = google_cloud_run_service.default[each.key].project
  service  = google_cloud_run_service.default[each.key].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}


resource "google_compute_region_network_endpoint_group" "default" {
  for_each = local.region_map

  provider              = google-beta
  name                  = "${var.name}--neg--${each.key}"
  network_endpoint_type = "SERVERLESS"
  region                = google_cloud_run_service.default[each.key].location
  cloud_run {
    service = google_cloud_run_service.default[each.key].name
  }
}

module "lb-http" {
  #   source            = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  #   version           = "~> 3.1"

  ## TODO: FIX THIS ONCE THE MODULE ABOVE TAGS A NEW RELEASE
  ## UNTIL THEN, USE GITHUB REPO REFERENCE
  source = "github.com/terraform-google-modules/terraform-google-lb-http/modules/serverless_negs"

  project = var.project_id
  name    = var.name

  ssl                             = false
  managed_ssl_certificate_domains = []
  https_redirect                  = false
  backends = {
    default = {
      description            = null
      enable_cdn             = false
      custom_request_headers = null

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        for neg in google_compute_region_network_endpoint_group.default:
        {
          group = neg.id
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
      security_policy = null
    }
  }
}

output "url" {
  value = "http://${module.lb-http.external_ip}"
}
