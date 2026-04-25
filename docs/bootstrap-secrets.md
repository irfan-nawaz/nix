# sops-nix bootstrap

1. Install age and sops:

   nix shell nixpkgs#age nixpkgs#sops -c zsh

2. Create an age key:

   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt

3. Extract your public key and place it in `secrets/.sops.yaml`.

4. Encrypt secrets:

   sops -e -i secrets/secrets.yaml

5. Rebuild:

   darwin-rebuild switch --flake .#irfan-personal

The module expects the age key file at `~/.config/sops/age/keys.txt`.
