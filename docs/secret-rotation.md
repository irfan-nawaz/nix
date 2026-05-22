# Secret rotation and recovery

Secrets in this repo are encrypted with [sops](https://github.com/getsops/sops)
against age recipients listed in `.sops.yaml`. The encrypted material lives in
`secrets/secrets.yaml` and is decrypted at activation time by sops-nix.

## Threat model

A single age recipient means losing the private key (`~/.config/sops/age/keys.txt`)
locks every encrypted SSH key permanently. Recovery requires at least one extra
recipient kept on a different device.

## Adding a recovery recipient

1. On the recovery device, generate a key pair:

   ```bash
   age-keygen -o ~/.config/sops/age/keys.txt
   ```

2. Copy the public line (`# public key: age1...`) into `.sops.yaml` under the
   `age:` list. Commit and push the config change.

3. Re-encrypt the existing payload against the new recipient set:

   ```bash
   sops updatekeys secrets/secrets.yaml
   git add secrets/secrets.yaml .sops.yaml
   git commit -m "secrets: add recovery recipient"
   ```

   `updatekeys` rewraps the data key only -- the underlying values are not
   re-encrypted, so the diff is small.

4. Verify both keys can decrypt:

   ```bash
   SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt \
     sops -d secrets/secrets.yaml >/dev/null && echo ok
   ```

## Rotating a leaked recipient

1. Generate a replacement key pair on the affected machine.
2. In `.sops.yaml`, remove the compromised public key and add the new one.
3. `sops updatekeys secrets/secrets.yaml`.
4. **Rotate every secret value** -- `updatekeys` only changes the wrapping
   layer, not the underlying material. The attacker still has the plaintext if
   they had the old private key:

   ```bash
   sops secrets/secrets.yaml         # edit values in $EDITOR
   ```

5. Reissue the corresponding upstream credentials (GitHub/GitLab SSH keys, API
   tokens) -- the threat is the leaked content, not the encryption.

## Recovery: primary key destroyed

If `~/.config/sops/age/keys.txt` on the primary laptop is gone:

1. From the recovery device, decrypt and edit the file in place (rewrites the
   ciphertext bound to the recipients still listed in `.sops.yaml`).
2. On the new primary device, regenerate a key pair, add its public line to
   `.sops.yaml`, run `sops updatekeys`.
3. Remove the dead recipient line and `updatekeys` once the new device is
   bootstrapped.

## Bootstrap on a new host

See `docs/fresh-host-bootstrap.md` (§5 covers age-key provisioning;
the rest of the doc walks the full first-time switch end-to-end).
