# GKE Terraform

To deploy using Terraform:

 * Create a new project on Google Cloud with [billing enabled](https://cloud.google.com/billing/docs/how-to/modify-project), and launch [Cloud Shell](https://cloud.google.com/shell/docs/using-cloud-shell).
 * Clone this repo (or open automatically in [Cloud Shell][shell_link])

    ```shell
    git clone https://github.com/Akio789/gke-terraform.git
    cd gke-terraform
    ```

  * Initialize and apply the Terraform manifests: 

    ```
    terraform init
    terraform plan
    terraform apply
    ```


## Learn more

 * [Managing Infrastructure as Code](https://cloud.google.com/solutions/managing-infrastructure-as-code)
 * [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine)

[shell_img]: http://gstatic.com/cloudssh/images/open-btn.png
[shell_link]: https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/Akio789/gke-terraform.git&page=editor&open_in_editor=terraform-serverless/README.md