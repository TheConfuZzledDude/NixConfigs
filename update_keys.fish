#!/usr/bin/env fish

for file in secrets.yaml **/secrets.env
    sops updatekeys $file
end
