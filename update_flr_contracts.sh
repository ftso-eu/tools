#!/bin/bash

# Clone the latest smart contract repository from Flare Network
git clone https://gitlab.com/flarenetwork/flare-smart-contracts.git tmp-contracts
cd tmp-contracts || exit
git fetch origin

# FLARE
git checkout flare_network_deployed_code
yarn && yarn c

# Create directories if they don't exist
mkdir -p ../src/artifacts/flare/typechain/factories
mkdir -p ../src/artifacts/songbird/typechain/factories

# Directory paths
artifacts_dir_flr="../src/artifacts/flare"
artifacts_dir_sgb="../src/artifacts/songbird"

# Contracts
contracts=(
  "ClaimSetupManager"
  "commons"
  "DistributionToDelegators"
  "Ftso"
  "FtsoManager"
  "FtsoRegistry"
  "FtsoRewardManager"
  "PollingFoundation"
  "PollingFtso"
  "PriceSubmitter"
  "Supply"
  "ValidatorRewardManager"
  "VPContract"
  "WNat"
)

# Copy specified TypeScript declaration files and factories to src/artifacts/flare/typechain
for contract in "${contracts[@]}"; do
  if [[ $contract != "index" ]]; then
    if [[ $contract == "commons" ]]; then
      cp -f "typechain/${contract}.ts" "$artifacts_dir_flr/typechain"
    else
      cp -f "typechain/${contract}.d.ts" "$artifacts_dir_flr/typechain"
      cp -f "typechain/factories/${contract}__factory.ts" "$artifacts_dir_flr/typechain/factories"
    fi
  fi
done

# Create the index.ts file in the flare/typechain directory
index_flr_file="$artifacts_dir_flr/typechain/index.ts"
{
  printf "// Factories\n"
  for contract in "${contracts[@]}"; do
    if [[ $contract != "index" ]]; then
      if [[ $contract != "commons" ]]; then
        printf "export { ${contract}__factory } from \"./factories/${contract}__factory\";\n"
      fi
    fi
  done

  printf "\n// Contracts\n"
  for contract in "${contracts[@]}"; do
    if [[ $contract != "index" ]]; then
      if [[ $contract != "commons" ]]; then
        printf "export type { ${contract} } from \"./${contract}\";\n"
      fi
    fi
  done
} > "$index_flr_file"

# Copy flare.json deployment file
cp -f deployment/deploys/flare.json "$artifacts_dir_flr"

# SONGBIRD
git checkout songbird_network_deployed_code
yarn && yarn c

# Copy specified TypeScript declaration files and factories to src/artifacts/songbird/typechain
for contract in "${contracts[@]}"; do
  if [[ $contract != "index" ]]; then
    if [[ $contract == "commons" ]]; then
      cp -f "typechain/${contract}.ts" "$artifacts_dir_sgb/typechain"
    else
      cp -f "typechain/${contract}.d.ts" "$artifacts_dir_sgb/typechain"
      cp -f "typechain/factories/${contract}__factory.ts" "$artifacts_dir_sgb/typechain/factories"
    fi
  fi
done

# Create the index.ts file in the songbird/typechain directory
index_sgb_file="$artifacts_dir_sgb/typechain/index.ts"
{
  printf "// Factories\n"
  for contract in "${contracts[@]}"; do
    if [[ $contract != "index" ]]; then
      if [[ $contract != "commons" ]]; then
        printf "export { ${contract}__factory } from \"./factories/${contract}__factory\";\n"
      fi
    fi
  done

  printf "\n// Contracts\n"
  for contract in "${contracts[@]}"; do
    if [[ $contract != "index" ]]; then
      if [[ $contract != "commons" ]]; then
        printf "export type { ${contract} } from \"./${contract}\";\n"
      fi
    fi
  done
} > "$index_sgb_file"

# Copy songbird.json deployment file
cp -f deployment/deploys/songbird.json "$artifacts_dir_sgb"

cd ..
rm -rf tmp-contracts

