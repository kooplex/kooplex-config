<?php
defined('BASEPATH') OR exit('No direct script access allowed');
/**
 * Created by PhpStorm.
 * User: davidt
 * Date: 2018.03.05.
 * Time: 9:34
 */

class Manage extends Base_Controller
{
    public function index(){
        $this->twig->display('manage/index');
    }
}
