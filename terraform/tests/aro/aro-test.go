package test

import (
	"context"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAROCluster(t *testing.T) {
	t.Parallel()

	// Set a longer timeout
	timeout := 30 * time.Minute
	terraformOptions := &terraform.Options{
		TerraformDir: "../../tf-aro",
		Vars: map[string]interface{}{
			"cluster_name":        "test-aro-cluster",
			"resource_group_name": "test-aro-rg",
			"pull_secret_path":    "~/Downloads/pull-secret.txt",
			"subscription_id":     "test-subscription-id",
			"aro_version":         "4.14.16",
			"location":            "eastus",
			"worker_node_count":   3,
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
		RetryableTerraformErrors: map[string]string{
			".*": "Throttling or transient error, retrying...",
		},
		// Add the timeout here
		NoColor:     true,
		Parallelism: 1,
		// Set the timeout for Terraform operations
		TerraformBinary: "terraform",
		EnvVars: map[string]string{
			"TF_CLI_ARGS":       "-no-color",
			"TF_CLI_ARGS_apply": "-lock=false -lock-timeout=5m",
		},
	}

	// Clean up resources after the test
	defer terraform.Destroy(t, terraformOptions)

	// Set a timeout for the entire test
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	// Run Init and Apply with the context
	_, err := terraform.InitAndApplyE(t, terraformOptions)
	if err != nil {
		select {
		case <-ctx.Done():
			t.Fatalf("Test timed out: %v", ctx.Err())
		default:
			t.Fatalf("Failed to create ARO cluster: %v", err)
		}
	}

	// Get outputs
	consoleURL := terraform.Output(t, terraformOptions, "console_url")
	apiURL := terraform.Output(t, terraformOptions, "api_url")

	// Assertions
	assert.NotEmpty(t, consoleURL, "Console URL should not be empty")
	assert.NotEmpty(t, apiURL, "API URL should not be empty")
}
