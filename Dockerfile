# ベースイメージとしてFullstaq Rubyを使用
ARG RUBY_VERSION=3.0.4
ARG VARIANT=jemalloc-slim
FROM quay.io/evl.ms/fullstaq-ruby:${RUBY_VERSION}-${VARIANT} as base

LABEL koyeb_runtime="rails"

# 環境変数の設定
ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

# 作業ディレクトリの作成
RUN mkdir /app
WORKDIR /app
RUN mkdir -p tmp/pids

# 必要なパッケージのインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    postgresql-client file vim curl gzip libsqlite3-0 build-essential libpq-dev \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Node.jsとYarnのインストール
RUN curl https://get.volta.sh | bash
ENV VOLTA_HOME /root/.volta
ENV PATH $VOLTA_HOME/bin:$PATH
RUN volta install node yarn

# Gemのインストール
COPY Gemfile* ./
RUN gem update --system --no-document && \
    gem install -N bundler && \
    bundle install --without development test && \
    rm -rf vendor/bundle/ruby/*/cache

# Nodeモジュールのインストール
COPY package*json yarn.* ./
RUN yarn install

# アプリケーションコードのコピー
COPY . .

# master.keyを設定するためのディレクトリを作成
RUN mkdir -p config

# RAILS_MASTER_KEYを使用してmaster.keyを生成
ARG RAILS_MASTER_KEY
RUN echo "$RAILS_MASTER_KEY" > config/master.key

# プリコンパイル
#RUN bundle exec rake assets:precompile

# デフォルトのコマンド
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "8080"]
