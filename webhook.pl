#!/usr/bin/env perl
use Mojolicious::Lite;
use JSON;
use Path::Tiny;

post '/' => sub {
  my $c = shift;
  if (my $payload = $c->req->param('payload')) {
    my $push = decode_json($payload);
    if (exists $push->{repository}) {
      my $hook = path($push->{repository}->{name})->absolute(path($0)->parent->child("hooks")->absolute);
      if (-x $hook) {
        if (fork()) {
          $c->app->log->info("call script");
        } else {
          exec($hook, $push->{repository}->{url}, $push->{ref});
        }
      }
    }
  }
  $c->res->headers->content_type('text/plain');
  $c->rendered(200);
};

app->start;
