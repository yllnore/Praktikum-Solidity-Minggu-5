// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Registrasi Hak Cipta Karya Multimedia
/// @notice Mengelola pencatatan hak cipta digital berbasis IPFS dengan kontrol akses
contract MediaCopyrightRegistry {
    
    // Custom Error untuk efisiensi Gas
    error UnauthorizedAccess(address caller);
    error MediaAlreadyExists(bytes32 mediaId);
    error MediaNotFound(bytes32 mediaId);
    error InvalidAddress();

    enum MediaType { Image, Audio, Video, Model3D }

    // Struct metadata karya multimedia (diperbarui dengan histori kepemilikan)
    struct MediaWork {
        bytes32 mediaId;
        string title;
        string ipfsHash;
        MediaType mediaType;
        address creator;
        uint256 timestamp;
        bool isVerified;
        address[] ownershipHistory; // Histori perubahan kepemilikan
    }

    address public admin;

    // Storage mappings
    mapping(bytes32 => MediaWork) private registry;
    mapping(address => bytes32[]) private creatorPortfolio;

    // Events
    event MediaRegistered(bytes32 indexed mediaId, address indexed creator, string ipfsHash);
    event MediaVerified(bytes32 indexed mediaId, address indexed verifier);
    event OwnershipTransferred(bytes32 indexed mediaId, address indexed previousOwner, address indexed newOwner);

    // Modifier untuk akses Admin
    modifier onlyAdmin() {
        if (msg.sender != admin) revert UnauthorizedAccess(msg.sender);
        _;
    }

    // Modifier untuk membatasi aksi hanya bagi pemilik karya saat ini
    modifier onlyCreator(bytes32 _mediaId) {
        if (registry[_mediaId].timestamp == 0) revert MediaNotFound(_mediaId);
        if (msg.sender != registry[_mediaId].creator) revert UnauthorizedAccess(msg.sender);
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @dev Mendaftarkan hak cipta media baru
    function registerMedia(
        string calldata _title,
        string calldata _ipfsHash,
        MediaType _mediaType
    ) external returns (bytes32) {
        require(bytes(_title).length > 0, "Judul tidak boleh kosong");
        require(bytes(_ipfsHash).length > 0, "IPFS Hash wajib diisi");

        bytes32 mediaId = keccak256(abi.encodePacked(msg.sender, _ipfsHash, block.timestamp));

        if (registry[mediaId].timestamp != 0) revert MediaAlreadyExists(mediaId);

        MediaWork memory newWork = MediaWork({
            mediaId: mediaId,
            title: _title,
            ipfsHash: _ipfsHash,
            mediaType: _mediaType,
            creator: msg.sender,
            timestamp: block.timestamp,
            isVerified: false,
            ownershipHistory: new address[](0)
        });

        registry[mediaId] = newWork;
        creatorPortfolio[msg.sender].push(mediaId);

        emit MediaRegistered(mediaId, msg.sender, _ipfsHash);
        return mediaId;
    }

    /// @dev Memindahkan hak cipta karya ke pemilik baru
    function transferCopyright(bytes32 _mediaId, address _newOwner) external onlyCreator(_mediaId) {
        if (_newOwner == address(0)) revert InvalidAddress();

        address previousOwner = registry[_mediaId].creator;

        // Catat pemilik lama ke dalam histori
        registry[_mediaId].ownershipHistory.push(previousOwner);

        // Alihkan hak cipta ke pemilik baru
        registry[_mediaId].creator = _newOwner;

        // Tambahkan karya ke portofolio penerima
        creatorPortfolio[_newOwner].push(_mediaId);

        emit OwnershipTransferred(_mediaId, previousOwner, _newOwner);
    }

    /// @dev Verifikasi karya oleh Admin
    function verifyMedia(bytes32 _mediaId) external onlyAdmin {
        if (registry[_mediaId].timestamp == 0) revert MediaNotFound(_mediaId);
        registry[_mediaId].isVerified = true;
        emit MediaVerified(_mediaId, msg.sender);
    }

    /// @dev Membaca metadata media (termasuk riwayat pemilik)
    function getMedia(bytes32 _mediaId) external view returns (MediaWork memory) {
        if (registry[_mediaId].timestamp == 0) revert MediaNotFound(_mediaId);
        return registry[_mediaId];
    }

    /// @dev Mengambil daftar ID karya milik pencipta/pemilik
    function getCreatorPortfolio(address _creator) external view returns (bytes32[] memory) {
        return creatorPortfolio[_creator];
    }
}