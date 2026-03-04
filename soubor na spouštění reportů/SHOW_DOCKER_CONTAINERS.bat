@echo off
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
pause