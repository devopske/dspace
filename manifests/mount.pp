$nfs_mounts = hiera_hash('nfs_mounts')
create_resources(gu_misc::mount_nfs_shares, $nfs_mounts)
