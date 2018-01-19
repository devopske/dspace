class gu_misc {

  define mount_nfs_shares(
        $mount_point,
        $mount_device) {
        
        include stdlib

        file{ $mout_point: ensure => directory }
        mount { $mount_point:
            device => $mount_device,
            name => $mount_point,
            require => File[$mount_point],
        }
    }

    create_resources('gu_misc::mount_nfs_shares', $nfs_mounts)

}
