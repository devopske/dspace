define profile::filed($title, $content) {
  notify { "The Name of config_file: ${title}": }
  notify { "The content of config_file: ${title} is: ${content}": }
  
  file {"$title":
          owner => root,
          group => root,
          mode => 644,
          content => $content
  }
  
  }
