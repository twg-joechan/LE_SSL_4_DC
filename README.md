Powershell Script to generate a new Certificate to be used for Domain Controllers - should not need to use this unless we want to restart from scratch again.
Powershell Script to renew the existing certificate to be used for the Domain Controllers (copied into the backup controller) - the same certificate (pkt) are then imported into ManagedEngine's ADSelfService to be used for SSL.

Same scripts can be used/modified for other internal SSL need (from Let's Encrypt).
