-- +goose Up
-- +goose StatementBegin
ALTER TABLE thunderdome.poker_story
ALTER COLUMN points TYPE VARCHAR(32);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE thunderdome.poker_story
ALTER COLUMN points TYPE VARCHAR(8)
USING LEFT(points, 8);
-- +goose StatementEnd
