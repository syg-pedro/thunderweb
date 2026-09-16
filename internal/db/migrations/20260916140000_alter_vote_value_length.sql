-- +goose Up
-- +goose StatementBegin
ALTER TYPE thunderdome.usersvote ALTER ATTRIBUTE vote TYPE VARCHAR(32) CASCADE;

ALTER TABLE thunderdome.project_item
ALTER COLUMN story_points TYPE VARCHAR(32);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TYPE thunderdome.usersvote ALTER ATTRIBUTE vote TYPE VARCHAR(8) CASCADE;

ALTER TABLE thunderdome.project_item
ALTER COLUMN story_points TYPE VARCHAR(8)
USING LEFT(story_points, 8);
-- +goose StatementEnd
