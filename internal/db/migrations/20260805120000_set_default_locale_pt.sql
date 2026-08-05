-- +goose Up
-- +goose StatementBegin
ALTER TABLE thunderdome.users ALTER COLUMN locale SET DEFAULT 'pt';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE thunderdome.users ALTER COLUMN locale DROP DEFAULT;
-- +goose StatementEnd
