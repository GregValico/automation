#!/bin/bash

gcloud compute networks subnets describe ${{ inputs.subnet_name }} --region=${{ inputs.region }}