<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>날씨 정보 앱</title>
    <!-- 제이쿼리, UI 추가 -->
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>

    <!-- 폰트어썸 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">

    <style>
        /* 전체 배경 스타일 */
        body {
            font-family: 'Arial', sans-serif; /* 폰트 스타일 설정 */
            background-color: #f0f8ff; /* 부드러운 배경색 */
            color: #333; /* 텍스트 색상 */
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center; /* 수평 중앙 정렬 */
            align-items: center; /* 수직 중앙 정렬 */
            height: 100vh; /* 전체 화면 높이 */
        }

        /* 컨테이너 스타일 */
        .container {
            text-align: center; /* 텍스트 중앙 정렬 */
            background-color: #fff; /* 흰색 배경 */
            border-radius: 10px; /* 모서리 둥글게 */
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2); /* 그림자 효과 */
            padding: 20px; /* 내부 여백 */
            width: 300px; /* 너비 설정 */
        }

        /* 입력 필드 스타일 */
        input[type="text"] {
            width: 80%; /* 입력 필드 너비 */
            padding: 10px; /* 내부 여백 */
            margin: 10px 0; /* 상하 여백 */
            border: 1px solid #ccc; /* 테두리 색상 */
            border-radius: 5px; /* 테두리 둥글게 */
        }

        /* 버튼 스타일 */
        button {
            background-color: #007bff; /* 버튼 배경색 */
            color: #fff; /* 버튼 텍스트 색상 */
            border: none; /* 테두리 제거 */
            padding: 10px 20px; /* 버튼 내부 여백 */
            border-radius: 5px; /* 버튼 모서리 둥글게 */
            cursor: pointer; /* 커서 포인터 */
            font-size: 16px; /* 글자 크기 */
        }

        /* 버튼 호버 효과 */
        button:hover {
            background-color: #0056b3; /* 호버 시 배경색 변경 */
        }

        /* 날씨 정보 스타일 */
        .weather-info {
            margin-top: 20px; /* 상단 여백 */
            text-align: left; /* 왼쪽 정렬 */
        }

    </style>
</head>

<body>

<div class="container"> <!-- 날씨 앱의 주요 컨테이너 -->
    <h1>날씨 정보 조회</h1> <!-- 앱 제목 -->
    <input type="text" id="cityInput" placeholder="도시 이름을 입력하세요"/> <!-- 도시 이름 입력 필드 -->
    <button id="getWeatherBtn">조회</button> <!-- 날씨 조회 버튼 -->
    <div id="weatherInfo" class="weather-info"></div> <!-- 날씨 정보 표시 영역 -->
</div>

<script>
    // OpenWeather API 설정: 발급받은 API 키를 여기에 입력
    const apiKey = 'YOUR_API_KEY';

    $(document).ready(function () {
        // 날씨 조회 버튼 클릭 이벤트 핸들러
        $('#getWeatherBtn').click(function () {
            getWeatherByCityName();
        });

        // 입력 필드에서 Enter 키가 눌렸을 때 날씨 조회
        $('#cityInput').keyup(function (event) {
            if (event.key === "Enter") { // Enter 키가 눌리면
                getWeatherByCityName();
            }
        });

        // 일정 간격으로 날씨 정보 갱신 (10분마다 자동 갱신)
        setInterval(getWeatherByCityName, 600000);
    });

    // 도시 이름을 기준으로 날씨를 조회하는 함수
    function getWeatherByCityName() {
        // 사용자 입력으로부터 도시 이름 가져오기
        const city = $('#cityInput').val();

        // 입력된 도시 이름이 없는 경우 경고 표시 후 함수 종료
        if (!city) {
            alert("도시 이름을 입력하세요.");
            return;
        }

        // Geocoding API를 통해 도시의 위도와 경도 찾기 (한글 도시명 검색 지원)
        $.ajax({
            url: 'https://api.openweathermap.org/geo/1.0/direct?q=' + city + '&limit=1&appid=' + apiKey,
            type: 'GET',
            dataType: 'json',
            success: function (data) {
                if (data.length > 0) {
                    const lat = data[0].lat;
                    const lon = data[0].lon;
                    // 여기에서 도시 이름을 사용자가 입력한 city로 설정 -> 한글로 보여주기 위해
                    getWeatherByCoordinates(lat, lon, city);
                } else {
                    alert("해당 도시를 찾을 수 없습니다.");
                }
            },
            error: function (error) {
                console.error("Error fetching coordinates:", error);
                alert("도시 정보를 가져오는 데 실패했습니다.");
            }
        });
    }

    // 위도와 경도를 기준으로 날씨를 조회하는 함수
    function getWeatherByCoordinates(lat, lon, cityName) {
        $.ajax({
            url: 'https://api.openweathermap.org/data/2.5/weather?lat=' + lat + '&lon=' + lon + '&appid=' + apiKey + '&units=metric&lang=kr',
            type: 'GET',
            dataType: 'json',
            success: function (data) {
                if (data.cod === 200) {
                    displayWeather(data, cityName);
                } else {
                    alert("날씨 정보를 찾을 수 없습니다.");
                }
            },
            error: function (error) {
                console.error("Error fetching weather data:", error);
                alert("날씨 데이터를 가져오는 데 실패했습니다.");
            }
        });
    }

    // 현재 시간을 반환하는 함수
    function getCurrentTime() {
        const now = new Date(); // 현재 시간 객체 생성
        return now.toLocaleString('ko-KR'); // 한국어 형식으로 날짜와 시간 반환
    }

    // 날씨 정보를 화면에 표시하는 함수
    function displayWeather(data, cityName) {
        const currentTime = getCurrentTime(); // 현재 시간 가져오기
        $('#weatherInfo').html(
            '<h2>' + cityName + ' 날씨</h2>' +
            '<p><strong>현재 시간:</strong> ' + currentTime + '</p>' + // 현재 시간 표시
            '<p><strong>온도:</strong> ' + data.main.temp + '°C</p>' +
            '<p><strong>습도:</strong> ' + data.main.humidity + '%</p>' +
            '<p><strong>풍속:</strong> ' + data.wind.speed + ' m/s</p>' +
            '<p><strong>상태:</strong> ' + data.weather[0].description + '</p>'
        );
    }

</script>

</body>
</html>
