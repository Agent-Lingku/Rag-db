# Makefile for company-antdv project

# Variables
REMOTE_REPO ?=
COMMIT_MSG ?= "Update project"
GITHUB_ACTIONS_URL ?= https://github.com/Fromsko/companyWebsite/actions
GITHUB_RELEASES_URL ?= https://github.com/Fromsko/companyWebsite/releases

# Default target
all: help

# Help target
help:
	@echo "Makefile Usage:"
	@echo "make dev          - Start the development environment"
	@echo "make build        - Build the project"
	@echo "make add NAME     - Add a component file named NAME"
	@echo "make add-remote   - configure/update Git remote repository"
	@echo "make bump-version - create a new semantic version tag"
	@echo "make commit       - commit your changes and select commit information"
	@echo "make push         - automatically commit, create new versions, and push to remote repositories"

# Core change in push target
push: check-remote
	@set -e; \
	CURRENT_BRANCH=$$(git symbolic-ref --short HEAD); \
	echo "🚀 启动自动化发布流程..."; \
	echo "▸ 当前工作分支: \033[1;34m$$CURRENT_BRANCH\033[0m"; \
	\
	echo "🔄 正在提交未保存的变更..."; \
	git add . || { echo "❌ 添加文件失败"; exit 1; }; \
	if git diff-index --quiet HEAD --; then \
		echo "🟢 工作区干净，无待提交变更"; \
	else \
		git commit -m "🔖 [自动提交] 版本发布前预处理" || { echo "❌ 提交失败"; exit 1; }; \
		echo "✅ 变更已提交（提交消息：🔖 [自动提交] 版本发布前预处理）"; \
	fi; \
	\
	echo "🆙 生成新版本标签..."; \
	$(MAKE) bump-version || { echo "❌ 版本标签生成失败"; exit 1; }; \
	\
	echo "📡 同步代码至GitHub..."; \
	git push origin $$CURRENT_BRANCH --follow-tags || { echo "❌ 代码/标签推送失败"; exit 1; }; \
	\
	echo "\n✅ 发布流程完成！以下步骤将自动进行："; \
	echo "  1. GitHub Actions 将触发构建流程（约1-2分钟）"; \
	echo "  2. GoReleaser 将生成多平台二进制文件"; \
	echo "  3. 新版本文档将自动发布到 GitHub Releases\n"; \
	echo "🔗 实时进度查看: $(GITHUB_ACTIONS_URL)"; \
	echo "🔗 发布结果查看: $(GITHUB_RELEASES_URL)"

check-remote:
	@echo "🔍 检查远程仓库配置..."; \
	if git remote | grep -q origin; then \
		echo "✓ 已配置远程仓库: \033[1;34m$$(git remote get-url origin)\033[0m"; \
	else \
		echo "❌ 错误：未配置远程仓库"; \
		echo "请先执行以下命令配置仓库地址："; \
		echo "   make add-remote <仓库URL>"; \
		echo "或通过交互模式配置：make add-remote"; \
		exit 1; \
	fi

# Add/update remote repository
add-remote:
	@# 捕获并验证URL参数
	@$(eval RAW_ARGS := $(filter-out $@,$(MAKECMDGOALS)))
	@$(eval REMOTE_REPO := $(shell echo '$(RAW_ARGS)' | grep -Eo '(git@|https?://)[a-zA-Z0-9./:@_-]+'))
	
	@if [ -n "$(REMOTE_REPO)" ]; then \
		if git remote | grep -q origin; then \
			git remote set-url origin $(REMOTE_REPO) >/dev/null; \
			echo "Remote origin updated to: $(REMOTE_REPO)"; \
		else \
			git remote add origin $(REMOTE_REPO) >/dev/null; \
			echo "Remote origin added: $(REMOTE_REPO)"; \
		fi; \
		exit 0; \
	fi; \
	
	@if [ -n "$(RAW_ARGS)" ]; then \
		echo "⚠️ Invalid repository URL: '$(RAW_ARGS)'"; \
		echo "Valid formats: git@... or https://..."; \
		exit 1; \
	fi; \
	
	@# 交互模式
	@if git remote | grep -q origin; then \
		current_url=$$(git remote get-url origin); \
		read -p "Current remote: $$current_url\nUpdate? [y/N]: " confirm; \
		if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
			read -p "Enter new URL: " REMOTE_REPO; \
			git remote set-url origin "$$REMOTE_REPO" >/dev/null; \
			echo "✓ Remote URL updated"; \
		else \
			echo "ℹ️ Keeping existing URL"; \
		fi; \
	else \
		read -p "Enter repository URL: " REMOTE_REPO; \
		git remote add origin "$$REMOTE_REPO" >/dev/null; \
		echo "✓ Remote origin added"; \
	fi;

# Commit changes with a message (include emoji)
commit:
	@if [ -z "$$(git status --porcelain)" ]; then \
		echo "No changes to commit. Exiting."; \
		exit 0; \
	fi; \
	echo "Select a commit message:"; \
	echo "1. 🚀 Initial commit"; \
	echo "2. ✨ Add new feature"; \
	echo "3. 🐛 Fix bug"; \
	echo "4. 📝 Update documentation"; \
	echo "5. 🔧 Refactor code"; \
	echo "6. 👍 Other"; \
	read -rp "Enter your choice (1-6): " choice; \
	choice=$$(echo "$$choice" | tr -cd '0-9'); \
	if [ -z "$$choice" ]; then \
		echo "Invalid input. Exiting."; \
		exit 1; \
	elif [ "$$choice" -eq 1 ]; then \
		COMMIT_MSG="🚀 Initial commit"; \
	elif [ "$$choice" -eq 2 ]; then \
		COMMIT_MSG="✨ Add new feature"; \
	elif [ "$$choice" -eq 3 ]; then \
		COMMIT_MSG="🐛 Fix bug"; \
	elif [ "$$choice" -eq 4 ]; then \
		COMMIT_MSG="📝 Update documentation"; \
	elif [ "$$choice" -eq 5 ]; then \
		COMMIT_MSG="🔧 Refactor code"; \
	elif [ "$$choice" -eq 6 ]; then \
		read -rp "Enter custom commit message: " COMMIT_MSG; \
	else \
		echo "Invalid choice. Exiting."; \
		exit 1; \
	fi; \
	git add .; \
	if git commit -m "$$COMMIT_MSG"; then \
		echo "Committed changes with message: $$COMMIT_MSG"; \
	else \
		echo "Commit failed (no changes to commit)."; \
	fi

# Bump version number
bump-version:
	@LATEST_TAG=$$(git describe --tags --abbrev=0 2>/dev/null); \
	if [ -z "$$LATEST_TAG" ]; then \
		NEW_VERSION="v0.1.0"; \
	else \
		NEW_VERSION=$$(echo $$LATEST_TAG | awk -F. '{major=substr($$1,2); print "v"major"."$$2"."($$3+1)}'); \
	fi; \
	git tag -a $$NEW_VERSION -m "Release $$NEW_VERSION"; \
	echo "New version tag $$NEW_VERSION created"

dev:
	@echo "Starting development environment..."
	vite

build:
	@echo "Building project..."
	vite build

add:
	@echo "Adding component $(NAME)..."
	@touch src/components/$(NAME)
	@echo "<template>" > src/components/$(NAME)
	@echo "  <div>" >> src/components/$(NAME)
	@echo "    <!-- Add your component content here -->" >> src/components/$(NAME)
	@echo "  </div>" >> src/components/$(NAME)
	@echo "</template>" >> src/components/$(NAME)
	@echo "" >> src/components/$(NAME)
	@echo "<script lang='ts'>" >> src/components/$(NAME)
	@echo "export default {" >> src/components/$(NAME)
	@echo "  name: '$(NAME:.vue=)'" >> src/components/$(NAME)
	@echo "}" >> src/components/$(NAME)
	@echo "</script>" >> src/components/$(NAME)
	@echo "" >> src/components/$(NAME)
	@echo "<style scoped>" >> src/components/$(NAME)
	@echo "/* Add your styles here */" >> src/components/$(NAME)
	@echo "</style>" >> src/components/$(NAME)