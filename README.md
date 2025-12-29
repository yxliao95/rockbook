# rockbook

## 更新Flutter版本

在根目录下运行以下命令：

```bash
flutter upgrade
flutter clean
flutter pub get
```

Dark会随着Flutter版本的更新而更新。
传递依赖不会出现在你的 pubspec.yaml 里，它们是由其它库间接带进来的。
要更新这些依赖，需要运行：

```bash
flutter pub upgrade --major-versions
```

## python 和 jupyter notebook 脚本支持

```bash
conda create -n rockbook python=3.11 -y
conda activate rockbook

python -m pip install -U pip
pip install notebook
conda install -n rockbook ipykernel --update-deps --force-reinstall

pip install beautifulsoup4 lxml selenium webdriver-manager

# Go to https://nodejs.org/zh-cn and install Node.js (which includes npm)
# install playwright
mkdir path
cd path
npm init playwright@latest
```
