data "null_data_source" "metadata_user_sshkeys_from_pubkeys" {
  count = length(var.github_accounts_for_ssh)
  inputs = {
    sshkeys = join(
      "\n",
      formatlist(
        "${element(var.github_accounts_for_ssh, count.index)}:%s",
        split(
          "\n",
          trimspace(
            file(
              format(
                "%s/tmp/users-keys/%s/pubkeys.txt",
                path.module,
                element(var.github_accounts_for_ssh, count.index)
              )
            )
          )
        )
      )
    )
  }
}

data "null_data_source" "metadata_all_users_sshkeys_from_user_sshkeys" {
  inputs = {
    sshkeys = join("\n", data.null_data_source.metadata_user_sshkeys_from_pubkeys[*].outputs.sshkeys)
  }
}
