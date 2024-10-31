package com.koreait.ygc_exam_24_10.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class WeatherController {

    @RequestMapping("/usr/home/weather")
    public String showWeather() {

        return "/usr/home/weather";
    }

}
