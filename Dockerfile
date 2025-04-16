# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.3.5
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# تثبيت الأدوات اللازمة
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# تحديد بيئة الإنتاج
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

FROM base AS build

# تثبيت الأدوات اللازمة للبناء
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# نسخ ملفات الجواهر وتثبيتها
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# نسخ باقي الملفات
COPY . .

# تثبيت الحزم الخاصة بـ JavaScript لو كنت تستخدم yarn
RUN yarn install

# إضافة المتغيرات البيئية المطلوبة للتجميع الصحيح
ARG SECRET_KEY_BASE
ARG RAILS_MASTER_KEY
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE \
    RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
    DATABASE_URL=postgresql://doesnt_matter_for_assets \
    RAILS_LOG_TO_STDOUT=true

# معالجة مفتاح التكوين
RUN if [ -f config/credentials.yml.enc ]; then \
    mkdir -p config/credentials && \
    touch config/credentials/production.key && \
    chmod 600 config/credentials/production.key; \
fi

# تعليق أو إزالة خطوة الـ assets:precompile مؤقتًا
# RUN ./bin/rails assets:precompile

FROM base

# نسخ كل الملفات من مرحلة البناء
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# إعدادات المستخدم
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER 1000:1000

# تعيين نقطة الإدخال
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80

# تشغيل الخادم
CMD ["./bin/thrust", "./bin/rails", "server"]