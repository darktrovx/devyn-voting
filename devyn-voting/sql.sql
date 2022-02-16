CREATE TABLE `player_voting` (
	`ElectionName` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`ElectionVotes` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
	`AlreadyVoted` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
	`CreateDate` DATE NOT NULL DEFAULT CURDATE(),
	UNIQUE INDEX `ElectionName` (`ElectionName`)
)