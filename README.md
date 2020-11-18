![](https://ahmet.im/blog/images/2020/07/cloud-run-multi-region.png)

# Multi-Region Cloud Run load balancing with Terraform

This example uses [Terraform
serverless_negs](https://github.com/terraform-google-modules/terraform-google-lb-http/tree/master/modules/serverless_negs)
module to deploy a Cloud Run service to [all
locations](https://cloud.google.com/run/docs/locations) and then create a
global Cloud HTTP Load Balancer with an anycast IP address to route your
users to the **nearest Cloud Run location**.

## Try it out

1. Initialize terraform modules:

    ```sh
    terraform init
    ```

1. See the execution plan (replace `PROJECT_ID` with yours)

    ```sh
    terraform plan -var=name=zoneprinter -var=project=PROJECT_ID
    ```

1. Apply the resources. (replace `PROJECT_ID` with yours)

    ```sh
    terraform apply -var=name=zoneprinter -var=project=PROJECT_ID
    ```

1. After deploying, it will print the load balancer’s IP address.

    ```sh
    url = http://34.107.196.62
    ```

    After waiting several minutes, the load balancer configuration will
    propagate globally and start working.

1. Users around the world will be connected to the **nearest Cloud Run
   location** that has the application deployed when they hit the load balancer.

   For example, a visitor from USA may see:

    ```text
    Welcome from Google Cloud datacenters at:
    The Dalles, Oregon, USA ("us-west1").
    ```

    And a visitor from Thailand might see:

    ```text
    Welcome from Google Cloud datacenters at:
    Jurong West, Singapore ("asia-southeast1").
    ```

1. Clean up after you’re done:

    ```sh
    terraform destroy -var=name=zoneprinter -var=project=PROJECT_ID
    ```

----

This is not an official project.
