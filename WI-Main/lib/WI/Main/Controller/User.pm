package WI::Main::Controller::User;
use base 'Mojolicious::Controller';

sub everyone_status {
    my $self = shift;
    $self->respond_to( json => sub {
        my $self = shift;
        my $everyone_status = $self->db->user->everyone_status;
        $self->render( json => { results => $everyone_status } );
    } );
}

sub channel_list {
    my $self = shift;
    $self->respond_to( json => sub {
        my $self  = shift;
        use DDP; warn p $self->req->json;
        warn "channel list ^^";
        my $user = $self
            ->db
            ->user
            ->find_or_create({
                username => $self->req->json->{nick}
            })
            ;
        my $results = $user
            ->channels
            ->list
            ->hashes
            ->to_array
            ;
        my $channel_list = [map { $_->{ channel } } @{ $results }];
        if ( ! scalar @{ $channel_list } ) {
            my @initial_channels = (qw|#general|);
            #set my initial list with everyone
            $user->channels->set( $self->db->channel->all );
            #TODO: Then control the frontend to make the user join all of these channels.
        }
        $self->render( json => { results => $channel_list } );
    } );
}

sub friend_list {
    my $self = shift;
    $self->respond_to( json => sub {
        my $self  = shift;
        my $user = $self
            ->db
            ->user
            ->find_or_create({
                username => $self->req->json->{nick}
            })
            ;
        my $results = $user
            ->friends
            ->list
            ->hashes
            ->to_array
            ;
        my $friend_list = [map { $_->{ nick } } @{ $results }];
        if ( ! scalar @{ $friend_list } ) {
            #set my initial list with everyone
            my $everyone = $user->everyone_status;
            $friend_list = [ map { $_->{ username } } @{ $everyone } ];
            $user->friends->set( $friend_list );
        }
        $self->render( json => { results => $friend_list } );
    } );
}

sub friend_add {
    my $self = shift;
    $self->respond_to( json => sub {
        my $self  = shift;
        my $user = $self
            ->db
            ->user
            ->find_or_create({
                username => $self->req->json->{user}
            })
            ;

        my $friend = $self
            ->db
            ->user
            ->find_or_create({
                username => $self->req->json->{friend}
            })
            ;

        if ( $user->id and $friend->id ) {
            $user->friends->add( $friend );
        }
        $self->render( json => { status => 'OK' } );
    } );
}

sub friend_del {
    my $self = shift;
    $self->respond_to( json => sub {
        my $self  = shift;
        my $user = $self
            ->db
            ->user
            ->find_or_create({
                username => $self->req->json->{user}
            })
            ;

        my $friend = $self
            ->db
            ->user
            ->find_or_create({
                username => $self->req->json->{friend}
            })
            ;

        if ( $user->id and $friend->id ) {
            $user->friends->del( $friend );
        }
        $self->render( json => { status => 'OK' } );
    } );
}

1;
