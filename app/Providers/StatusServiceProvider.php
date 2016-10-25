<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

/**
 * Class StatusServiceProvider
 * @package App\Providers
 */
class StatusServiceProvider extends ServiceProvider
{
    /**
     * Indicates if loading of the provider is deferred.
     *
     * @var bool
     */
    protected $defer = false;

    /**
     * Package boot method
     */
    public function boot()
    {
    }

    /**
     * Register the service provider.
     *
     * @return void
     */
    public function register()
    {
        $this->registerBindings();
    }

    /**
     * Register service provider bindings
     */
    public function registerBindings()
    {

        $this->app->bind(
            \App\Repositories\Backend\Status\StatusRepositoryContract::class,
            \App\Repositories\Backend\Status\EloquentStatusRepository::class
        );
    }
}