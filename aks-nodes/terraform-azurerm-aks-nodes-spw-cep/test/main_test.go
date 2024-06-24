package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"

)

func TestTerraformMain(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "./",
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

}