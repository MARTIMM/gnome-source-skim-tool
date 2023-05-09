#`{{
# can only run with "setenv RAKUDO_RAKUAST 1"

# dd displays what is build in the pod structures
dd $=pod

=begin pod
=begin comment
=begin code
…
=end code
=end comment
=end pod
}}


#`{{
# showed by the 'dd $=pod'
[Pod::Block::Named.new(name => "pod", config => {}, contents => [Pod::Block::Comment.new(config => {}, contents => ["=begin code\n…\n=end code\n"])])]
}}


# This works without using RAKUDO_RAKUAST env var.
# worked out code
[ Pod::Block::Named.new(
    :name<pod>, :config({}),
    contents => [ Pod::Block::Comment.new(
        :config({}),
        contents => ["=begin code\n…\n=end code\n"]
      ),
    ]
  ),
]

