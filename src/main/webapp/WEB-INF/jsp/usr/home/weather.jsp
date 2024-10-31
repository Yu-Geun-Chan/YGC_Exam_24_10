<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>${pageTitle }</title>
    <link rel="stylesheet" href="/resource/common.css"/>
    <link rel="stylesheet" href="/resource/gameSchedule.css"/>
    <script src="/resource/common.js" defer="defer"></script>
    <!-- 제이쿼리, UI 추가 -->
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>

    <!-- 폰트어썸 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }

        .main-content {
            max-width: 800px;
            margin: auto;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 20px;
        }

        #weather-container {
            display: flex;
            flex-wrap: wrap;
            gap: 20px; /* 각 날씨 정보 사이의 간격 */
        }

        .stadium-weather {
            flex: 1 1 calc(50% - 20px); /* 두 개의 열로 나누기 */
            background: #e3f2fd; /* 연한 파란색 배경 */
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 1px 5px rgba(0, 0, 0, 0.1);
            transition: transform 0.2s;
        }

        .stadium-weather:hover {
            transform: scale(1.02); /* 마우스 오버 시 확대 효과 */
        }

        h3 {
            margin: 0 0 10px;
            color: #1e88e5; /* 제목 색상 */
        }

        p {
            margin: 5px 0;
            color: #555; /* 본문 색상 */
        }

        #search-container {
            margin-bottom: 20px;
        }

        #search-input {
            padding: 10px;
            width: 100%;
            border-radius: 4px;
            border: 1px solid #ccc;
        }

        #search-button {
            padding: 10px;
            background-color: #1e88e5;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        #search-button:hover {
            background-color: #0d7aef;
        }
    </style>
</head>

<body>

<div class="main-content">
    <div id="search-container">
        <input type="text" id="search-input" placeholder="도시 이름을 입력하세요..." />
        <button id="search-button">검색</button>
    </div>
    <div id="weather-container"></div>
</div>

<script>
    const apiKey = 'Your_API_Key';

    $(document).ready(function() {
        // 초기화: 지정된 경기장의 날씨를 가져옵니다.
        fetchWeatherForStadiums();

        // 검색 버튼 클릭 시 이벤트 리스너 추가
        $('#search-button').on('click', function() {
            const city = $('#search-input').val();
            fetchWeatherForCity(city);
        });
    });

    function fetchWeatherForStadiums() {
        const stadiums = [
            { name: '잠실', lat: 37.5122579, lon: 127.0719011 },
            { name: '수원', lat: 37.2997553, lon: 127.0096685 },
            { name: '고척', lat: 37.498, lon: 126.867 },
            { name: '인천', lat: 37.4370423, lon: 126.6932617 },
            { name: '대전', lat: 36.3170789, lon: 127.4291345 },
            { name: '사직', lat: 35.1940316, lon: 129.0615183 },
            { name: '창원', lat: 35.2225335, lon: 128.5823895 },
            { name: '대구', lat: 35.8411705, lon: 128.6815273 },
            { name: '광주', lat: 35.1681242, lon: 126.8891056 },
        ];

        let weatherResults = new Array(stadiums.length); // 날씨 정보를 저장할 배열

        $.each(stadiums, function(index, stadium) {
            $.ajax({
                url: `https://api.openweathermap.org/data/2.5/weather`,
                type: 'GET',
                data: {
                    lat: stadium.lat,
                    lon: stadium.lon,
                    appid: apiKey,
                    units: 'metric',
                    lang: 'kr'
                },
                success: function(data) {
                    const weatherInfo = {
                        name: stadium.name,
                        temp: data.main.temp,
                        description: data.weather.length > 0 ? data.weather[0].description : '정보 없음',
                        humidity: data.main.humidity,
                        windSpeed: data.wind.speed
                    };
                    weatherResults[index] = weatherInfo;

                    if (weatherResults.every(result => result !== undefined)) {
                        displayWeather(weatherResults);
                    }
                },
                error: function() {
                    console.log('날씨 데이터를 불러오는 중 오류가 발생했습니다.');
                }
            });
        });
    }

    function fetchWeatherForCity(city) {
        $.ajax({
            url: `https://api.openweathermap.org/data/2.5/weather`,
            type: 'GET',
            data: {
                q: city, // 도시 이름
                appid: apiKey,
                units: 'metric',
                lang: 'kr'
            },
            success: function(data) {
                const weatherInfo = {
                    name: data.name,
                    temp: data.main.temp,
                    description: data.weather.length > 0 ? data.weather[0].description : '정보 없음',
                    humidity: data.main.humidity,
                    windSpeed: data.wind.speed
                };
                displayWeather([weatherInfo]); // 단일 결과로 표시
            },
            error: function() {
                alert('해당 도시의 날씨 정보를 찾을 수 없습니다.');
            }
        });
    }

    function displayWeather(results) {
        $('#weather-container').empty(); // 기존 내용 비우기
        results.forEach(result => {
            const weatherHtml = `
                <div class="stadium-weather">
                    <h3>` + result.name + `</h3>
                    <p>온도: ` + result.temp + ` °C</p>
                    <p>날씨: ` + result.description + `</p>
                    <p>습도: ` + result.humidity + `%</p>
                    <p>풍속: ` + result.windSpeed + ` m/s</p>
                </div>
            `;
            $('#weather-container').append(weatherHtml); // 결과를 DOM에 추가
        });
    }
</script>

</body>
</html>
