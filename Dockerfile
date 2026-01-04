# Стадия 1: Сборка приложения
FROM maven:3-eclipse-temurin-17 AS build
WORKDIR /build
COPY pom.xml .
# Загружаем зависимости отдельно для кэширования слоя
RUN mvn dependency:go-offline -B
COPY src ./src
# Собираем приложение
RUN mvn package -DskipTests -B

# Стадия 2: Создание минимального JRE с jlink
FROM eclipse-temurin:17-jdk-jammy AS jre-build
# Распаковываем Spring Boot JAR
WORKDIR /app
COPY --from=build /build/target/orcestra-final-0.0.1-SNAPSHOT.jar app.jar
RUN jar -xf app.jar && rm app.jar
# Создаем минимальный JRE только с необходимыми модулями для Spring Boot
RUN jlink \
    --add-modules java.base,java.logging,java.xml,java.naming,java.desktop,java.management,java.sql,java.instrument \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /javaruntime

# Стадия 3: Финальный минимальный образ
FROM gcr.io/distroless/base-debian12
# Копируем минимальный JRE
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
COPY --from=jre-build /javaruntime $JAVA_HOME
# Копируем распакованное приложение для лучшей работы с Docker layers
WORKDIR /app
COPY --from=jre-build /app/BOOT-INF/lib ./lib
COPY --from=jre-build /app/META-INF ./META-INF
COPY --from=jre-build /app/BOOT-INF/classes ./classes
# Запускаем приложение с оптимизированными параметрами JVM для контейнера
ENTRYPOINT ["java", \
    "-XX:+UseContainerSupport", \
    "-XX:MaxRAMPercentage=75.0", \
    "-XX:+TieredCompilation", \
    "-XX:TieredStopAtLevel=1", \
    "-noverify", \
    "-cp", \
    "classes:lib/*", \
    "ru.mephi.orcestrafinal.OrcestraFinalApplication"]
