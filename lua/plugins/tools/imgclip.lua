return {
  {
    "HakonHarnes/img-clip.nvim",
    opts = {
      filetypes = {
        markdown = {
          prompt_for_file_name = false,
          template = "[Image]($FILE_PATH)",
          use_absolute_path = true,
        },
      },
    },
  },
}
