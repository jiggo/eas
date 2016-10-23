<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

/**
 * Class SkillServiceProvider
 * @package App\Providers
 */
class SkillServiceProvider extends ServiceProvider
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
            \App\Repositories\Backend\Skill\SkillRepositoryContract::class,
            \App\Repositories\Backend\Skill\EloquentSkillRepository::class
        );
    }
}