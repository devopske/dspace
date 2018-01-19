define profile::file($title, $content) {
  notify { "The Name of config_file: ${title}": }
  notify { "The content of config_file: ${title} is: ${content}": }
  
  }
