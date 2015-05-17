<?php
class ApplyFilterExtension extends Twig_Extension
{
    public function getName()
    {
        return 'apply_filter';
    }

    public function getFilters()
    {
        return array(
            'apply_filter' =>
                new \Twig_SimpleFilter(
                    'apply_filter',
                    array($this, 'applyFilter'),
                    array(
                        'needs_environment' => true,
                        'needs_context' => true,
                    )
                )
        );
    }

    public function applyFilter(Twig_Environment $env, $context = array(), $value, $filters)
    {
        $old_env = $env->getLoader();
        $env = new Twig_Environment(new Twig_Loader_String(), array('cache' => false, 'autoescape' => false));

        $name = 'apply_filter_' . md5($filters);
        
        $template = sprintf('{{ %s|%s }}', $name, $filters);
        $template = $env->loadTemplate($template);

        $context[$name] = $value;
        $finale = $template->render($context);
        
        $env = $env->setLoader($old_env);
        return $finale;
    }

}