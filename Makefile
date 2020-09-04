.PHONY: all
all: update_dhall.yaml update_dhall.json update_jsonnet.json

update_dhall.yaml: update.dhall tasks/*.dhall
	dhall-to-yaml < update.dhall > $@

update_dhall.json: update.dhall tasks/*.dhall
	dhall-to-json < update.dhall > $@

update_jsonnet.json: update.jsonnet tasks/*.libsonnet
	jsonnet update.jsonnet > $@
