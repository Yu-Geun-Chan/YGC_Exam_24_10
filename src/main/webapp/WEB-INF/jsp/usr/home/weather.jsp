<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>날씨 및 관광 정보 앱</title>
    <!-- 제이쿼리, UI 추가 -->
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>

    <!-- 폰트어썸 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">

    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f0f8ff;
            color: #333;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .container {
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
            padding: 20px;
            width: 80%;
            max-width: 1000px;
        }

        input[type="text"] {
            width: 80%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 5px;
        }

        button {
            background-color: #007bff;
            color: #fff;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }

        button:hover {
            background-color: #0056b3;
        }

        .info-container {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }

        .weather-info, .tourist-info {
            width: 48%;  /* 두 정보가 50%씩 차지하도록 설정 */
            margin-top: 20px;
            text-align: left;
            padding: 15px;
            border: 1px solid #ccc;
            border-radius: 8px;
        }

        .weather-info {
            background-color: #e3f2fd;
        }

        .tourist-info {

            background-color: #e8f5e9;
        }

        h2 {
            margin-top: 0;
        }

        #prevPage {
            margin-right: 10px;
        }
    </style>

<body>

<div class="container">
    <h1>날씨 및 관광 정보 조회</h1>
    <input type="text" id="cityInput" placeholder="도시 이름을 입력하세요"/>
    <button id="getWeatherBtn">조회</button>

    <!-- 날씨와 관광지 정보를 가로로 배치하는 컨테이너 -->
    <div class="info-container">
        <div id="weatherInfo" class="weather-info"></div>
        <div id="touristInfo" class="tourist-info"></div> <!-- 관광지 정보 영역 추가 -->
    </div>
</div>

<script>
    const apiKey = 'YOUR_API_KET';  // OpenWeather API 키

    $(document).ready(function () {
        $('#getWeatherBtn').click(function () {
            getWeatherByCityName();
        });

        $('#cityInput').keyup(function (event) {
            if (event.key === "Enter") {
                getWeatherByCityName();
            }
        });

        setInterval(getWeatherByCityName, 600000); // 10분마다 자동 갱신
    });

    function getWeatherByCityName() {
        const city = $('#cityInput').val();

        if (!city) {
            alert("도시 이름을 입력하세요.");
            return;
        }

        // 도시 이름으로 위도와 경도 얻기
        $.ajax({
            url: 'https://api.openweathermap.org/geo/1.0/direct?q=' + city + '&limit=1&appid=' + apiKey,
            type: 'GET',
            dataType: 'json',
            success: function (data) {
                if (data.length > 0) {
                    const lat = data[0].lat;
                    const lon = data[0].lon;
                    getWeatherByCoordinates(lat, lon, city);
                    getTouristInfoByCoordinates(lat, lon);  // 위도, 경도를 사용하여 관광지 정보 가져오기
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

    function getTouristInfoByCoordinates(lat, lon) {
        const touristApiKey = 'YOUR_API_KET';  // 공공데이터 포털 API 키

        $.ajax({
            url: 'https://apis.data.go.kr/B551011/KorService1/locationBasedList1?serviceKey=' + touristApiKey + '&numOfRows=10&pageNo=1&MobileApp=AppTest&_type=json&MobileOS=ETC&mapX=' + lon + '&mapY=' + lat + '&radius=1000&contentTypeId=12',
            type: 'GET',
            dataType: 'json',
            success: function (data) {
                if (data.response.body.totalCount > 0) {
                    displayTouristInfo(data);
                } else {
                    $('#touristInfo').html('<p>해당 지역에 대한 관광 정보가 없습니다.</p>');
                }
            },
            error: function(error) {
                console.error("Error fetching tourist info:", error); // 에러내용 출력
                alert("관광 정보를 가져오는 데 실패했습니다.");
            }
        });
    }

    function displayWeather(data, cityName) {
        const currentTime = new Date().toLocaleString('ko-KR');
        $('#weatherInfo').html(
            '<h2>' + cityName + ' 날씨</h2>' +
            '<p><strong>현재 시간:</strong> ' + currentTime + '</p>' +
            '<p><strong>온도:</strong> ' + data.main.temp + '°C</p>' +
            '<p><strong>습도:</strong> ' + data.main.humidity + '%</p>' +
            '<p><strong>풍속:</strong> ' + data.wind.speed + ' m/s</p>' +
            '<p><strong>상태:</strong> ' + data.weather[0].description + '</p>'
        );
    }

    let currentPage = 1; // 현재 페이지 상태
    const itemsPerPage = 5; // 한 페이지에 표시할 관광지 개수
    let currentLat = null; // 현재 위도
    let currentLon = null; // 현재 경도

    function getTouristInfoByCoordinates(lat, lon) {
        currentLat = lat;  // 현재 위도 저장
        currentLon = lon;  // 현재 경도 저장

        const touristApiKey = 'aToHYG4xpZhS0OS59VRMVuioU5pgfn7mwvbBFbfnODC0%2Fwmwbx8DQbKtcoXyk7HXNCX9BNanoAQtqaxjpgrTJg%3D%3D';  // 관광지 API 키

        $.ajax({
            url: 'https://apis.data.go.kr/B551011/KorService1/locationBasedList1?serviceKey=' + touristApiKey + '&numOfRows=' + itemsPerPage + '&pageNo=' + currentPage + '&MobileApp=AppTest&_type=json&MobileOS=ETC&mapX=' + lon + '&mapY=' + lat + '&radius=20000&contentTypeId=12',
            type: 'GET',
            dataType: 'json',
            success: function (data) {
                if (data.response.body.totalCount > 0) {
                    displayTouristInfo(data);
                    updatePagination(data.response.body.totalCount);
                } else {
                    $('#touristInfo').html('<p>해당 지역에 대한 관광 정보가 없습니다.</p>');
                }
            },
            error: function(error) {
                console.error("Error fetching tourist info:", error); // 에러내용 출력
                alert("관광 정보를 가져오는 데 실패했습니다.");
            }
        });
    }

    function displayTouristInfo(data) {
        let touristHtml = '<h2>추천 관광지</h2>';

        // items 배열을 가져옴
        const items = data.response.body.items.item;

        // items 배열을 순회하면서 HTML을 생성
        items.forEach(function(item) {
            const title = item.title || '명소 정보 없음';  // title 값이 없으면 기본값
            const addr = item.addr1 || '주소 미제공';  // addr1 값이 없으면 기본값

            touristHtml += '<p><strong>명소:</strong> ' + title + '</p>';
            touristHtml += '<p><strong>주소:</strong> ' + addr + '</p>';
            touristHtml += '<hr>';
        });

        // HTML을 특정 요소에 삽입
        document.getElementById("touristInfo").innerHTML = touristHtml;
    }

    function updatePagination(totalCount) {
        const totalPages = Math.ceil(totalCount / itemsPerPage); // 총 페이지 수 계산
        let paginationHtml = '';

        // 이전 페이지 버튼 추가
        if (currentPage > 1) {
            paginationHtml += '<button id="prevPage" onclick="changePage(' + (currentPage - 1) + ')">이전</button>';
        }

        // 다음 페이지 버튼 추가
        if (currentPage < totalPages) {
            paginationHtml += '<button id="nextPage" onclick="changePage(' + (currentPage + 1) + ')">다음</button>';
        }

        // 페이지네이션 버튼을 HTML에 삽입
        document.getElementById("touristInfo").innerHTML += paginationHtml;
    }

    function changePage(page) {
        currentPage = page;  // 페이지 변경
        getTouristInfoByCoordinates(currentLat, currentLon);  // 새로운 페이지의 데이터를 가져옵니다
    }

</script>

</body>
</html>
