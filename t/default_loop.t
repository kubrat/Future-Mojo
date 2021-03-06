use strict;
use warnings;

BEGIN { $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll' }

use Test::More;
use Test::Identity;

use Future::Mojo;

{
	my $future = Future::Mojo->new();
	
	$future->loop->next_tick(sub { $future->done('result') });
	
	is_deeply [$future->get], ['result'], '$future->get on Future::Mojo';
}

# done_next_tick
{
	my $future = Future::Mojo->new();
	
	identical $future->done_next_tick('deferred result'), $future, '->done_next_tick returns $future';
	ok !$future->is_ready, '$future not yet ready after ->done_next_tick';
	
	is_deeply [$future->get], ['deferred result'], '$future now ready after ->get';
}

# fail_next_tick
{
	my $future = Future::Mojo->new();
	
	identical $future->fail_next_tick("deferred exception\n"), $future, '->fail_next_tick returns $future';
	ok !$future->is_ready, '$future not yet ready after ->fail_next_tick';
	
	$future->await;
	
	is_deeply [$future->failure], ["deferred exception\n"], '$future now ready after $future->await';
}

# new_timer
{
	my $future = Future::Mojo->new_timer(0.1);
	
	$future->await;
	ok $future->is_ready, '$future is ready from new_timer';
	is_deeply [$future->get], [], '$future->get returns empty list on new_timer';
}

# timer cancellation
{
	my $called;
	my $future = Future::Mojo->new_timer(0.1)->on_done(sub { $called++ });
	
	$future->cancel;
	
	Future::Mojo->new_timer(0.3)->await;
	
	ok $future->is_ready, '$future has been canceled';
	ok !$called, '$future->cancel cancels a pending timer';
}


done_testing;
