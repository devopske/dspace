#hiera_include('classes')
$nfs_mounts = hiera('nfs_mounts')
create_resources('gu_misc::mount_nfs_shares', $nfs_mounts)
