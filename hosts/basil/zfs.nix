{
  services.zfs = {
    # Trimming informs the underlying storage devices of all blocks in the pool
    # which are no longer allocated and allows thinly provisioned devices to
    # reclaim the space.
    # In order for auto-trim to work, it must be set on the pool:
    # `sudo zpool set autotrim=on <pool>`
    trim.enable = true;
    trim.interval = "weekly";

    # Scrubbing examines all data in the specified pools to verify that it
    # checksums correctly.
    autoScrub.enable = true;
    autoScrub.interval = "monthly";

    # Snapshots are read-only copies of a filesystem taken at a moment in time.
    # In order for auto-snapshot to work, it must be set on the dataset:
    # `sudo zfs set com.sun:auto-snapshot=true <dataset>`
    autoSnapshot.enable = true;
    autoSnapshot.monthly = 3;
  };
}
