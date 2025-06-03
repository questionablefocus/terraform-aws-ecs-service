resource "aws_efs_file_system" "main" {
  count                           = var.efs_root_directory != null ? 1 : 0
  creation_token                  = "${var.name}-storage"
  performance_mode                = "generalPurpose"
  throughput_mode                 = "provisioned"
  provisioned_throughput_in_mibps = 100
  encrypted                       = true
}

resource "aws_efs_access_point" "main" {
  count          = var.efs_root_directory != null ? 1 : 0
  file_system_id = aws_efs_file_system.main[0].id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = var.efs_root_directory
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }
}

resource "aws_security_group" "efs" {
  count       = var.efs_root_directory != null ? 1 : 0
  name_prefix = "${var.name}-efs-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.main.id]
  }
}

resource "aws_efs_mount_target" "main" {
  count           = var.efs_root_directory != null ? length(var.subnet_ids) : 0
  file_system_id  = aws_efs_file_system.main[0].id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs[0].id]
}
