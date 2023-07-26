CREATE OR REPLACE FUNCTION is_requested_following_user(profile_row profiles, hasura_session json)
RETURNS boolean AS $$
SELECT EXISTS (
    SELECT 1
    FROM following A
    WHERE A.follower_profile_id = (hasura_session ->> 'x-hasura-user-id')::uuid AND A.following_profile_id = profile_row.id AND A.is_accepted = false
);
$$ LANGUAGE sql STABLE;
