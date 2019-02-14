#!/bin/bash
rm -rf cookbooks/*
berks package
tar -xzf cookbooks-*.tar.gz
rm cookbooks-*.tar.gz
